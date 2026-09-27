// § genScopeTrailSelNameLate184: generate-scope continuous assignments and an initial block, and an interface generate scope
typedef struct packed { logic [7:0] f; } s_t;
interface bus_if (input s_t s);
  logic a;
  if (1) begin : gi
    logic b;
    always_comb b = s.f[3];
  end
endinterface
module top #(parameter bit P = 1) (input s_t s, input logic [2:0] i, output logic y, output logic x);
  bus_if bi (.s(s));
  if (P) begin : ga
    assign y = s.f[i];
    logic q;
    initial q = s.f[2];
    assign x = q;
  end
endmodule
