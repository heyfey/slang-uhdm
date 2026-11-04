// § invalidReadDefAdmit448
module m #(parameter P) (input clk);
  task automatic t(); endtask
  function automatic void f(); t(); endfunction
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
