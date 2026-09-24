package p223c;
   int    mv_one223;
   string mv_two223;
   int    mv_arr223 [2];
endpackage

module m223a;
   import p223c::*;
   int ownm223;
endmodule

module m223b;
   import p223c::*;
   int ownm223b;
endmodule

module top223c;
   m223b u223b();
endmodule
