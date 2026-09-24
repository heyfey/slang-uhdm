package p223d;
   int    iv_one223;
   string iv_two223;
endpackage

interface if223d();
   import p223d::*;
   int owni223;
endinterface

module top223d;
   if223d u_if223();
endmodule
