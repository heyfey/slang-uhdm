module top;
  function automatic int f();
    begin
      int q[5];
      q[0] = 1;
      return q[0];
    end
  endfunction
endmodule
