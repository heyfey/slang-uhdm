package p223b;
   int    pv_one223;
   int    pv_two223;
endpackage

interface if223b();
   import p223b::pv_one223;
   int own223b;
endinterface

interface if223c();
   import p223b::pv_two223;
   import p223b::*;
   int own223c;
endinterface
