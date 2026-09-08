// r10v218 arm b4 — MIS-TARGETING.  Two uninstantiated interfaces and three
// subroutines all use the SAME formal and local NAMES.  A census that records
// only the KIND of the vpiActual cannot see a reference bound to the WRONG
// io_decl; this arm exists so the verifier's own scorer (which records the
// actual's NAME and LINE) can.
interface if4v_a;
   bit mv4v;
   function void f4v(int a_n);
      int l4v;
      if (a_n == 1) mv4v = 1'b1;     // x01
      if (l4v == 1) mv4v = 1'b1;     // x02
      c4v(a_n);                      // x03
      c4v(l4v);                      // x04
   endfunction
   function void g4v(int a_n);       // SAME formal name, different function
      int l4v;                       // SAME local name
      if (a_n == 2) mv4v = 1'b1;     // x05
      if (l4v == 2) mv4v = 1'b1;     // x06
      c4v(a_n);                      // x07
      c4v(l4v);                      // x08
   endfunction
   function void c4v(int z); endfunction
endinterface

interface if4v_b;                    // SAME names again, other interface
   bit mv4v;
   function void f4v(int a_n);
      int l4v;
      if (a_n == 3) mv4v = 1'b1;     // x09
      if (l4v == 3) mv4v = 1'b1;     // x10
      c4v(a_n);                      // x11
      c4v(l4v);                      // x12
   endfunction
   function void c4v(int z); endfunction
endinterface

module top4v;
   initial begin end
endmodule
