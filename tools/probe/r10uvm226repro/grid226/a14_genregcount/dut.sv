// arm a14: HOW MANY COPIES of a `generate ... endgenerate` REGION process does
// a DEFINITION list, per holder and per instance count?  The module road models
// "one per instance, instance loop outermost" (ModuleEmit.cpp's regionPbs x
// defAllInstCount); a10 showed golden giving an UNINSTANTIATED interface ONE
// copy, which that rule cannot produce.  This arm reads the whole table.
//   if226_r0  interface, region with TWO processes, ZERO instances
//   if226_r1  interface, region with TWO processes, ONE instance
//   if226_r2  interface, region with TWO processes, TWO instances
//   mod226_r0 module,    region with TWO processes, ZERO instances
//   mod226_r1 module,    region with TWO processes, ONE instance
//   mod226_r2 module,    region with TWO processes, TWO instances
// Each holder writes ONE own process first, so the own/region split is visible
// in the vector's positions.
interface if226_r0();
   logic a226, b226, c226;
   initial begin a226 = 1'b0; end
   generate
      initial begin b226 = 1'b0; end
      initial begin c226 = 1'b0; end
   endgenerate
endinterface

interface if226_r1();
   logic a226, b226, c226;
   initial begin a226 = 1'b0; end
   generate
      initial begin b226 = 1'b0; end
      initial begin c226 = 1'b0; end
   endgenerate
endinterface

interface if226_r2();
   logic a226, b226, c226;
   initial begin a226 = 1'b0; end
   generate
      initial begin b226 = 1'b0; end
      initial begin c226 = 1'b0; end
   endgenerate
endinterface

module mod226_r0;
   logic a226, b226, c226;
   initial begin a226 = 1'b0; end
   generate
      initial begin b226 = 1'b0; end
      initial begin c226 = 1'b0; end
   endgenerate
endmodule

module mod226_r1;
   logic a226, b226, c226;
   initial begin a226 = 1'b0; end
   generate
      initial begin b226 = 1'b0; end
      initial begin c226 = 1'b0; end
   endgenerate
endmodule

module mod226_r2;
   logic a226, b226, c226;
   initial begin a226 = 1'b0; end
   generate
      initial begin b226 = 1'b0; end
      initial begin c226 = 1'b0; end
   endgenerate
endmodule

module top226_r;
   if226_r1  u_i1226();
   if226_r2  u_i2a226();
   if226_r2  u_i2b226();
   mod226_r1 u_m1226();
   mod226_r2 u_m2a226();
   mod226_r2 u_m2b226();
endmodule
