// § strNetRefMintsNet422
module top;
  logic data, gate;
  trireg (large) #(0,0,50) cap1;
  nmos nmos1 (cap1, data, gate);
  initial begin
    $monitor("%v", cap1);
    data = 1;
  end
endmodule
