// r10buvm33repro/g33a3.sv — § foreachScopedArrayWrittenClassVar33, ARM 3:
// HOMES, INSTANCE COUNTS and TOKEN SHAPES.  An interface, a program, a task,
// an always block and a generate loop with two instances; an ESCAPED
// identifier as the qualifier; a PARAMETERIZED middle segment; and the
// negative controls that must keep their pristine shape.  MEASUREMENT ONLY.
package s33;
  class cell33;
    static int cq33[$];
  endclass
  class \esc33 ;
    static int eq33[$];
  endclass
  class par33 #(int W = 1);
    static int pq33[$];
  endclass
endpackage

interface if33;
  import s33::*;
  int iq33[$];
  function void ifun33();
    foreach (cell33::cq33[i])            // I1  interface home
      iq33.push_back(1);
    foreach (iq33[i])                    // I2  bare control
      iq33.push_back(1);
  endfunction
endinterface

program pr33;
  import s33::*;
  int pq33[$];
  initial begin
    foreach (cell33::cq33[i])            // R1  program home
      pq33.push_back(1);
    foreach (s33::cell33::cq33[i])       // R2  three segments
      pq33.push_back(1);
  end
endprogram

module leaf33 #(parameter int K = 0);
  import s33::*;
  int lq33[$];
  task automatic tk33();
    foreach (cell33::cq33[i])            // K1  TASK home, two instances
      lq33.push_back(1);
  endtask
  always @* begin
    foreach (cell33::cq33[i])            // K2  ALWAYS home, two instances
      lq33.push_back(1);
  end
endmodule

module top33a3;
  import s33::*;
  int tq33[$];
  genvar gi33;
  generate
    for (gi33 = 0; gi33 < 2; gi33++) begin : g33
      leaf33 #(.K(gi33)) u33 ();         // TWO instances of leaf33
    end
  endgenerate
  if33 if_u33 ();
  initial begin
    foreach (\esc33 ::eq33[i])           // E1  ESCAPED qualifier
      tq33.push_back(1);
    foreach (par33#(2)::pq33[i])         // E2  PARAMETERIZED qualifier
      tq33.push_back(1);
    foreach (s33::par33#(2)::pq33[i])    // E3  package :: parameterized class
      tq33.push_back(1);
    foreach (tq33[i])                    // E4  bare control
      tq33.push_back(1);
  end
endmodule
