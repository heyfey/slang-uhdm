package p224e;
   typedef logic [3:0] te224_t;
endpackage

module child224 #(parameter type T = int) ();
   T c_sig224;
endmodule

interface if224e();
   import p224e::*;
   typedef logic [1:0] loce224_t;
   loce224_t f_tp224;                 // typedef used as a child's type param arg
   child224 #(.T(loce224_t)) u_c();
endinterface

interface if224f(.g_ext224(g_int224));   // explicit (non-ANSI) port
   import p224e::*;
   typedef logic [1:0] locf224_t;
   input g_int224;
   locf224_t g_loc224;
endinterface

module m224e();
   import p224e::*;
   typedef logic [1:0] locm224_t;
   locm224_t h_tp224;
   child224 #(.T(locm224_t)) u_cm();
endmodule

module top224e;
endmodule
