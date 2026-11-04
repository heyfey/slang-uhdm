// § ppOutputLine166
`define CONN(p, s) .p(s)
module sub(input logic a, input logic b, output logic y);
  assign y = a & b;
endmodule
module top(input logic a, input logic b, output logic y);
  sub u(`CONN(a, a),
        `CONN(b, b),
        .y(y));
endmodule
