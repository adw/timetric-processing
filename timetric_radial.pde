import java.util.Calendar;
/**
 * How to get data from Timetric and display it using Processing.
 *
 * @author Andrew Walkingshaw <andrew@inkling-software.co.uk>
 * @version 0.5
 */

interface Plottable2D {
  void plot(int[] centre, int[] inner_box, int[] outer_box);
}

class Series {
  Calendar[] times;
  float[] values;
  String id;

  // constructors  
  Series() {
    // default constructor
  }

  Series(String series_id) {
    setID(series_id);
    loadData();
  } 

  // setters
  void setID(String series_id) {
    id = series_id;
  }
  
  void loadData() {
    // Load in the history of a series from its CSV endpoint
    String URL = getHistoryURL();
    try {
      String[] data = loadStrings(URL);
      int len = data.length;
      times = new Calendar[len];
      values = new float[len];
      for (int x=0; x<len; x++) {
        String[] fragments = data[x].split(",");
        long dst = 1000L * int(fragments[0]);
        Calendar c = Calendar.getInstance();
        // all times on Timetric are in UTC.
        c.setTimeInMillis(dst);
        times[x] = c;
        float ev = float(fragments[1]);
        values[x] = ev;
      }
    } catch (NullPointerException e) {
      println("Series failed to load:" + URL);
    }
  }

  // getters
  String getID() {
    return id;
  }
  
  String getURL() {
    return "http://timetric.com/series/"+id+"/";
  }
  
  String getHistoryURL() {
    return("http://timetric.com/series/"+id+"/csv/");
  }

  float[] getValues() {
    return values;
  }
  
  Calendar[] getTimes() {
    return times;
  }
}

class WeeklyRadialSeries extends Series implements Plottable2D {
  // Collapse a series onto a radial plot, folded week-by-week
  int ellipse_size = 4;
  
  WeeklyRadialSeries(String series_id) {
    super(series_id);
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
  // Collapse a series onto a radial plot, folded day-by-day
  int ellipse_size = 4;
  
  HourlyRadialSeries(String series_id) {
    super(series_id);
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
  // the ID here is http://timetric.com/series/SERIES_ID/ 
  HourlyRadialSeries data = new HourlyRadialSeries("tmUuYRsgTPCF_2qu4NrL_Q");
  int[] wh1 = {width/4, height/4};
  data.plot(wh1, radial, bounding);
  int[] wh2 = {3*width/4, 3*height/4};
  HourlyRadialSeries new_data = new HourlyRadialSeries("u1G90heAQp2DmRgCD46bLQ");
  new_data.plot(wh2, radial, bounding);
  WeeklyRadialSeries w_data = new WeeklyRadialSeries("tmUuYRsgTPCF_2qu4NrL_Q");
  int[] wh3 = {3*width/4, height/4};
  w_data.plot(wh3, radial, bounding);
  WeeklyRadialSeries new_w_data = new WeeklyRadialSeries("u1G90heAQp2DmRgCD46bLQ");
  int[] wh4 = {width/4, 3*height/4};
  new_w_data.plot(wh4, radial, bounding);
}
