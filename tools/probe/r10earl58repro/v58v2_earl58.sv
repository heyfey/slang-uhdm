// v58 VERIFIER arm V2 — CONTEXTS the grid did not spell: always_latch, final,
// fork/join inside always, repeat/while/for statement bodies, a function CALL
// from a gen-scope always (currentSubSym), a task body, a named begin, a
// case-statement item, an if condition, and initial (must NOT fold).
module v2_earl58 (input logic clk, input logic en, input logic [63:0] v,
                  output logic [63:0] o);
  if (1) begin : g1
    localparam int unsigned L = 6;
    if (1) begin : g2
      logic [63:0] r_lat, r_fin, r_fork, r_fcall, r_task, r_rep, r_for,
                   r_init, r_nb, r_if, r_case, r_whl;
      always_latch if (en) r_lat = v[L-2:0];
      final r_fin = v[L-2:0];
      always @(posedge clk) fork r_fork <= v[L-2:0]; join
      function automatic logic [63:0] f(input logic [63:0] x);
        return x[L-2:0];
      endfunction
      always_comb r_fcall = f(v);
      task automatic t(output logic [63:0] y);
        y = v[L-2:0];
      endtask
      always_comb t(r_task);
      always @(posedge clk) repeat (2) r_rep <= v[L-2:0];
      always @(posedge clk) for (int k = 0; k < 2; k++) r_for <= v[L-2:0];
      always @(posedge clk) while (en) r_whl <= v[L-2:0];
      initial r_init = v[L-2:0];
      always @(posedge clk) begin : nb
        r_nb <= v[L-2:0];
      end
      always_comb begin
        if (v[L-2:0] != 0) r_if = 1; else r_if = 0;
      end
      always_comb begin
        case (v[L-2:0])
          0: r_case = 1;
          default: r_case = 2;
        endcase
      end
      assign o = r_lat ^ r_fin ^ r_fork ^ r_fcall ^ r_task ^ r_rep ^ r_for ^
                 r_init ^ r_nb ^ r_if ^ r_case ^ r_whl;
    end
  end
endmodule
