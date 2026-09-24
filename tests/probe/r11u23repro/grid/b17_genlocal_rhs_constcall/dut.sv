module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  function automatic int f7(); return 7; endfunction
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = f7();
    assign o2 = lv;
  end
endmodule
