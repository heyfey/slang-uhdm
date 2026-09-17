// r11u58 xd4 — WHICH READER TRIGGERS.  Five identical pattern localparams in
// one package; each is read by exactly ONE reader kind.  The const-function
// read (wd3) is the known trigger; this arm asks which OTHER reads reach
// CompileHelper::getValue("pk::NAME") and so run expandPatternAssignment on
// the package's own elaborated Rhs.
//   R1 argument of a const function call in a MODULE PARAMETER default (wd3)
//   R2 argument of a const function call in a MODULE LOCALPARAM
//   R3 argument of a const function call in a PACKAGE localparam (same package)
//   R4 whole read as a module localparam initialiser
//   R5 read inside a cont_assign only
package pk;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    logic [7:0]  D;
    logic [15:0] F;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t R1 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t R2 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t R3 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t R4 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam u_t R5 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };
  localparam r_t K3 = build(R3);
endpackage
module dut #(parameter pk::r_t P = pk::build(pk::R1)) (output logic [31:0] o);
  localparam pk::r_t L2 = pk::build(pk::R2);
  localparam pk::u_t L4 = pk::R4;
  assign o = P.X + L2.X + L4.A + pk::R5.A + pk::K3.X;
endmodule
