// § contAssignLhsTsUnparented134
module leaf #(parameter bit EN = 0) (input logic c, output logic [3:0] o);
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  s_t s;
  if (EN) begin : g
    assign s = '{x: 4'h3, y: c};
  end else begin : h
    always_comb s = '0;
  end
  assign o = s.x;
endmodule
module top(input logic c, output logic [3:0] o1, o2);
  leaf #(1) u1(.c(c), .o(o1));
  leaf #(0) u0(.c(c), .o(o2));
endmodule
