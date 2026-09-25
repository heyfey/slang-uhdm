module top(output logic [1:0] o);
  function automatic logic [1:0] f();
    logic [1:0] a [2];
    a[0] = 2'd1;
    a[1] = 2'd2;
    return a[1];
  endfunction
  assign o = f();
endmodule
