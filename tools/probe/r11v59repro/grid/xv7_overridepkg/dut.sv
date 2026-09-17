// v11u59 xv7 — THE PACKAGE PARAMETER OVERRIDDEN PER INSTANCE, and a NON-package
// holder of the same shape.  § patElabUintResize is gated `inPackage`; a module
// holding the identical struct pattern must be untouched by the removal, and a
// package parameter whose pattern is re-read by two differently-parameterised
// instances must land one value, not a last-writer race.
package pk;
  localparam int unsigned BIG = 300;
  typedef struct packed {
    logic [7:0]   M;
    logic [127:0] W;
    int unsigned  Z;
  } u_t;
  localparam u_t PBASE = '{ M: BIG, W: 128'(0), Z: unsigned'(64) };
endpackage
module holder #(parameter int unsigned K = 1) (output logic [31:0] o);
  // the SAME shape, held by a MODULE: the arm must not fire here
  localparam pk::u_t MBASE = '{ M: pk::BIG, W: 128'(0), Z: unsigned'(64) };
  assign o = MBASE.M + K;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] a, b, c;
  holder #(.K(1)) h1 (.o(a));
  holder #(.K(2)) h2 (.o(b));
  assign c = pk::PBASE.M;
  assign o = a ^ b ^ c;
endmodule
