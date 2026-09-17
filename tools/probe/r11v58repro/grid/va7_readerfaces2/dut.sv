// v11u58 va7 — READER LOCATIONS THE r11u58 GRID DID NOT CUT.
//   K1: a call-argument read inside ANOTHER PACKAGE's localparam (parameter
//       context, qualified) — gate TRUE.
//   K2: a call-argument read inside an INTERFACE parameter port default.
//   K3: a call-argument read in a PACKED DIMENSION of a net (a constant
//       context that is NOT a parameter) — gate FALSE; does golden stamp?
//   K4: never read (control).
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  function automatic int unsigned wid(u_t c);
    return c.A[7:0];
  endfunction
  localparam u_t K1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };
  localparam u_t K2 = '{ A: 64, B: unsigned'(64), D: 32'(5) };
  localparam u_t K3 = '{ A: 64, B: unsigned'(64), D: 32'(5) };
  localparam u_t K4 = '{ A: 64, B: unsigned'(64), D: 32'(5) };
endpackage
package other;
  localparam int unsigned W1 = pk::wid(pk::K1);
endpackage
interface iface #(parameter int unsigned W2 = pk::wid(pk::K2)) ();
  logic [W2-1:0] bus;
endinterface
module dut (output logic [31:0] o);
  logic [pk::wid(pk::K3)-1:0] net3;
  iface i0 ();
  assign net3 = '0;
  assign o = other::W1 + $bits(net3) + $bits(i0.bus);
endmodule
