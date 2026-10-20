// § stdRandomizeFuncCall413
module top;
  bit [15:0] addr;
  bit [31:0] data;
  function bit gen();
    bit success, rd_wr;
    success = randomize(addr, data, rd_wr);
    return rd_wr;
  endfunction
endmodule
