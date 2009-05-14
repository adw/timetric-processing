import java.util.Calendar;

interface Plottable2D {
  void plot(int[] centre, int[] inner_box, int[] outer_box);
}

class Series {
  Calendar[] times;
  float[] values;

  Series() {
    // default constructor
  }
  
  Series(String URL) {
    loadData(URL);
  } 
 
  void loadData(String URL) {
    try {
      String[] data = loadStrings(URL);
      int len = data.length;
      times = new Calendar[len];
      values = new float[len];
      for (int x=0; x<len; x++) {
        String[] fragments = data[x].split(",");
        long dst = 1000L * int(fragments[0]);
        Calendar c = Calendar.getInstance();
        c.setTimeInMillis(dst);
        times[x] = c;
        float ev = float(fragments[1]);
        values[x] = ev;
      }
    } catch (NullPointerException e) {
      println("Series failed to load:" + URL);
    }
  }

  float[] getValues() {
    return values;
  }
  
  Calendar[] getTimes() {
    return times;
  }
}

class WeeklyRadialSeries extends Series implements Plottable2D {
  int ellipse_size = 4;
  
  WeeklyRadialSeries(String URL) {
    super(URL);
  }
  
  void plot(int[] centre, int[] inner_box, int[] outer_box) {
    int cx = centre[0]; int cy = centre[1];
    int radius = min(inner_box)/2;
    int count_radius = min(outer_box)/2;
    float last_x = width/2;
    float last_y = height/2;
    float maxval = max(values);
    float segment = (360.0/7);
    
    for (int y=0; y<times.length; y++) {
      float ev = (values[y]/maxval) * radius;
      int day = times[y].get(Calendar.DAY_OF_WEEK);
      int hour = times[y].get(Calendar.HOUR_OF_DAY);      
      int minute = times[y].get(Calendar.MINUTE);
      float deg_ang = segment*day + (segment/24)*hour + (segment/(24*60))*minute;
      float rad_ang = radians(deg_ang);
      float px = (cx + ev*sin(rad_ang));
      float py = (cy - ev*cos(rad_ang));
      ellipse(px, py, ellipse_size, ellipse_size);
      px = last_x; py=last_y;
    }
    pushStyle();
    fill(0, 0, 0, 127);
    for (float x=0; x<7; x++) {
      text(int(x+1), cx + float(count_radius)*sin(radians(segment*x)),
                     cy - float(count_radius)*cos(radians(segment*x)));
    }
    popStyle();
  }
}

class HourlyRadialSeries extends Series implements Plottable2D {
  int ellipse_size = 4;
  
  HourlyRadialSeries(String URL) {
    super(URL);
  }
  
  void plot(int[] centre, int[] inner_box, int[] outer_box) {
    int cx = centre[0]; int cy = centre[1];
    int radius = min(inner_box)/2;
    int count_radius = min(outer_box)/2;
    float last_x = width/2;
    float last_y = height/2;
    float maxval = max(values);

    for (int y=0; y<times.length; y++) {
      float ev = (values[y]/maxval) * radius;
      int hour = times[y].get(Calendar.HOUR_OF_DAY);
      int minute = times[y].get(Calendar.MINUTE);
      float deg_ang = 15*hour + 0.25*minute;
      float rad_ang = radians(deg_ang);
      float px = (cx + ev*sin(rad_ang));
      float py = (cy - ev*cos(rad_ang));
      ellipse(px, py, ellipse_size, ellipse_size);
      px = last_x; py=last_y;
    }
    
    pushStyle();
    fill(0, 0, 0, 127);
    for (float x=0; x<24; x++) {
      text(int(x), cx + float(count_radius)*sin(radians(15*x)),
                   cy - float(count_radius)*cos(radians(15*x)));
    }
    popStyle();
  }
}

void setup() {
  int radius = 250;
  int count_radius = 275;
  size(600, 600);
  PFont display_font;
  display_font = loadFont("HelveticaNeue-Bold-16.vlw");
  textFont(display_font);
  background(255);
  smooth();
  noStroke();
  fill(127, 0, 0);
  int[] radial = {radius, radius};
  int[] bounding = {count_radius, count_radius};
  HourlyRadialSeries data = new HourlyRadialSeries("http://timetric.com/series/tmUuYRsgTPCF_2qu4NrL_Q/csv/");
  int[] wh1 = {width/4, height/4};
  data.plot(wh1, radial, bounding);
  int[] wh2 = {3*width/4, 3*height/4};
  HourlyRadialSeries new_data = new HourlyRadialSeries("http://timetric.com/series/u1G90heAQp2DmRgCD46bLQ/csv/");
  new_data.plot(wh2, radial, bounding);
  WeeklyRadialSeries w_data = new WeeklyRadialSeries("http://timetric.com/series/tmUuYRsgTPCF_2qu4NrL_Q/csv/");
  int[] wh3 = {3*width/4, height/4};
  w_data.plot(wh3, radial, bounding);
  WeeklyRadialSeries new_w_data = new WeeklyRadialSeries("http://timetric.com/series/u1G90heAQp2DmRgCD46bLQ/csv/");
  int[] wh4 = {width/4, 3*height/4};
  new_w_data.plot(wh4, radial, bounding);
}



