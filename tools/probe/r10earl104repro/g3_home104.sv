// r10earl104 g3 -- THE HOME GRID.  MEASUREMENT ONLY.
// The SAME declaration (`logic [7:0] X = {8{1'b1}}`) in every home the emitter
// distinguishes: a PACKAGE (where golden's folded Rhs carries NO typespec at
// all -- earl55's pk5_55::PKW1 fence), a MODULE, a CLASS, a GENERATE SCOPE, an
// INTERFACE, a FUNCTION body, and THREE INSTANCES of one module (one span, three
// elaborated cells).  NO reader in any of them.
package pk3_104;
  localparam logic [7:0] PX = {8{1'b1}};
endpackage
interface if3_104();
  localparam logic [7:0] IX = {8{1'b1}};
endinterface
class c3_104;
  localparam logic [7:0] CX = {8{1'b1}};
endclass
module g3_home104(input logic ext, output logic o);
  m_e1 u_e1(); m_e2 u_e2(); m_e3 u_e3();     // three instances of ONE span
  m_e4 u_e4();                               // a generate scope
  m_e5 u_e5();                               // a function body
  if3_104 u_if();
  localparam logic [7:0] TX = {8{1'b1}};     // the TOP module's own
  assign o = ext;
endmodule
module m_e1(); localparam logic [7:0] X = {8{1'b1}}; endmodule
module m_e2(); localparam logic [7:0] X = {8{1'b1}}; endmodule
module m_e3(); localparam logic [7:0] X = {8{1'b1}}; endmodule
module m_e4();
  for (genvar k = 0; k < 2; k++) begin : g
    localparam logic [7:0] GX = {8{1'b1}};
  end
endmodule
module m_e5();
  function automatic logic [7:0] f3_104();
    localparam logic [7:0] FX = {8{1'b1}};
    return FX;
  endfunction
  localparam logic [7:0] Y = f3_104();
endmodule
