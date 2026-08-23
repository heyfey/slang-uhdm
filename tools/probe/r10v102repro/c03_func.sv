module c03;
  function automatic int f03;
    localparam FL = 'b101;
    return FL;
  endfunction
  task automatic t03;
    localparam TL = 'h1a;
    $display("%0d", TL);
  endtask
  initial $display("%0d", f03());
endmodule
