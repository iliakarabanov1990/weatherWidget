public with sharing class GeoJSON2Apex {
    public String name;
	public Local_names local_names;
	public Double lat;
	public Double lon;
	public String country;

	public class Local_names {
		public String th;
		public String ml;
		public String lt;
		public String fa;
		public String cv;
		public String la;
		public String et;
		public String ka;
		public String no;
		public String it;
		public String mk;
		public String pt;
		public String en;
		public String cu;
		public String nl;
		public String lv;
		public String ja;
		public String el;
		public String fi;
		public String ug;
		public String zh;
		public String ar;
		public String sv;
		public String is;
		public String hr;
		public String sl;
		public String tg;
		public String de;
		public String bg;
		public String kk;
		public String hi;
		public String yi;
		public String ga;
		public String fr;
		public String eo;
		public String kv;
		public String es;
		public String io;
		public String vo;
		public String kn;
		public String ia;
		public String bo;
		public String ta;
		public String ascii;
		public String uk;
		public String feature_name;
		public String ko;
		public String mr;
		public String he;
		public String ku;
		public String oc;
		public String sr;
		public String hu;
		public String hy;
		public String pl;
		public String ru;
		public String sk;
		public String os;
		public String ur;
		public String tt;
		public String gl;
		public String cs;
		public String ky;
		public String be;
		public String vi;
	}

	
	public static List<GeoJSON2Apex> parse(String json) {
		return (List<GeoJSON2Apex>) System.JSON.deserialize(json, List<GeoJSON2Apex>.class);
	}
}