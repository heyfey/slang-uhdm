// § defGenPathSel161 § hpSelRoute157 — one selected scope path written in a gen-if target (definition view) and read in a module-level select index
module top(input logic [3:0] a, output logic y);
  if (1) begin : A
    wire [1:0] k;
    if (1) begin : B
      assign A.k[1:0] = 2'd2;
    end
  end
  assign y = a[A.k];
endmodule
