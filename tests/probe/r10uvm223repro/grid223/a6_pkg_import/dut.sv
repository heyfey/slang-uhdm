package p223g;
   int    gv_one223;
endpackage

package p223h;
   import p223g::*;
   int    hv_one223;
endpackage

interface if223g();
   import p223h::*;
   int owng223;
endinterface
