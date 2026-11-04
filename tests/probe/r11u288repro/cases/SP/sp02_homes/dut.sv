// § streamPartSelLazyName288 — the homes: package function, class method, module function and task, for-generate (control: the prefix branch)
package sp;
  function automatic logic [7:0] pf(input logic [7:0] v);
    return {<< 2 {v[3:0], 4'h1}};
  endfunction
endpackage
class sc;
  logic [7:0] q;
  function logic [7:0] cf(input logic [7:0] v);
    return {<< 2 {v[3:0], q[7:4]}};
  endfunction
endclass
module d29 #(parameter int W = 8)(input logic [7:0] i, output logic [7:0] t0, t1, t2, o1);
  function automatic logic [7:0] mf(input logic [7:0] v);
    mf = {<< 4 {v[3:0], i[7:4]}};
  endfunction
  task automatic mt(output logic [7:0] r);
    r = {<< 2 {i[W-1:4], i[3:0]}};
  endtask
  assign o1 = {>> 4 {i[3:0], i[7:4]}};
  always_comb t0 = mf(i) ^ sp::pf(i);
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [7:0] gq;
    assign gq = {<< 2 {i[3:0], i[g+4]}};
    always_comb begin
      t1 = {<< 2 {gq[3:0], i[7:4]}};
    end
  end
  initial mt(t2);
endmodule
