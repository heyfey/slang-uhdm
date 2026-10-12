// § streamPartSelLazyName288 — streaming part-selects of a struct member, a module parameter, a package parameter, an unpacked element and with a byte slice type
package pq; localparam logic [7:0] PP = 8'h5a; endpackage
module top #(parameter logic [7:0] P = 8'h3c)(input logic [15:0] w, output logic [15:0] t0, t1, t2, t3);
  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  s_t s;
  assign s = w;
  always_comb begin
    t0 = {<< {s.f[3:0], s.g[7:4]}};
    t1 = {<< {P[3:0], pq::PP[7:4]}};
    t2 = {<< byte {w[15:0]}};
    t3 = {<< 4 {w[11:4], P[7:0]}};
  end
endmodule
