// r10v218 arm b2 — INTERFACE SHAPES.  Which interface definitions does
// `defAllInstCount[&def] == 0` reach, and does the law behave at each?  The
// INSTANTIATED interface and the module are the MUST-NOT-MOVE controls.
interface if2v_mp;                   // uninstantiated, HAS A MODPORT
   bit clk2v;
   bit dat2v;
   modport mst (input clk2v, output dat2v);
   modport slv (input clk2v, input dat2v);
   function void fmp2v(int a_m);
      int lmp2v;
      if (a_m == 1) dat2v = 1'b1;    // m01 formal in a cond
      if (dat2v == 1'b1) dat2v = 1'b0; // m02 interface MEMBER in a cond
      cmp2v(a_m);                    // m03 formal, call-stmt arg
      cmp2v(lmp2v);                  // m04 local, call-stmt arg
   endfunction
   function void cmp2v(int z); endfunction
endinterface

interface if2v_p #(parameter int W2V = 4) (input bit pclk2v);  // PARAMETERIZED + PORT
   bit [W2V-1:0] pv2v;
   function void fp2v(int a_p);
      int lp2v;
      if (a_p == 1) pv2v = '0;       // p01 formal in a cond
      if (W2V == 1) pv2v = '0;       // p02 PARAMETER in a cond
      if (pclk2v) pv2v = '0;         // p03 interface PORT in a cond
      cp2v(a_p);                     // p04 formal, call arg
      cp2v(lp2v);                    // p05 local, call arg
      cp2v(W2V);                     // p06 PARAMETER, call arg
      cp2v(int'(pclk2v));            // p07 PORT under a cast, call arg
   endfunction
   function void cp2v(int z); endfunction
endinterface

interface if2v_cls;                  // uninstantiated, CONTAINS A CLASS
   bit cv2v;
   class inner2v;
      int prop2v;
      function void im2v(int a_i);
         int li2v;
         if (a_i == 1) prop2v = 1;   // c01 class-method formal in a cond
         if (li2v == 1) prop2v = 1;  // c02 class-method local in a cond
         if (prop2v == 1) prop2v = 2; // c03 class PROPERTY in a cond
         ci2v(a_i);                  // c04 class-method formal, call arg
      endfunction
      function void ci2v(int z); endfunction
   endclass
   function void fc2v(int a_c);
      if (a_c == 1) cv2v = 1'b1;     // c05 iface-fn formal, cond
   endfunction
endinterface

interface if2v_inst;                 // INSTANTIATED — MUST NOT MOVE
   bit iv2v;
   function void fi2v(int a_q);
      int li2v;
      if (a_q == 1) iv2v = 1'b1;     // i01 formal in a cond
      if (iv2v) iv2v = 1'b0;         // i02 iface member in a cond
      ci2v(a_q);                     // i03 formal, call arg
      ci2v(li2v);                    // i04 local, call arg
   endfunction
   function void ci2v(int z); endfunction
endinterface

module mod2v_uninst;                 // uninstantiated MODULE — control
   bit dv2v;
   function void fm2v(int a_w);
      int lm2v;
      if (a_w == 1) dv2v = 1'b1;     // u01 formal in a cond
      if (dv2v) dv2v = 1'b0;         // u02 module member in a cond
      cm2v(a_w);                     // u03 formal, call arg
      cm2v(lm2v);                    // u04 local, call arg
   endfunction
   function void cm2v(int z); endfunction
endmodule

module top2v;
   if2v_inst u_inst();               // the ONLY instantiation in the file
   initial begin end
endmodule
