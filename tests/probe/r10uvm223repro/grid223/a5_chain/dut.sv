package p223e;
   int    ev_one223;
endpackage

package p223f;
   import p223e::*;
   int    fv_one223;
endpackage

interface if223e();
   import p223f::*;
   import p223e::*;
   int owne223;
endinterface
