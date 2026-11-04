// § tfItemInitLocalAtType209: a CRLF file
module top;
  function int cf;
    int a = 1;
    byte b = 8'd2;
    return a + b;
  endfunction
  int r;
  initial r = cf();
endmodule
