class box #(int W = 8);
  logic [W-1:0] d;
  box #(W) next;
  function logic [W-1:0] get(); return d; endfunction
endclass
typedef box#(16) box16_t;
module top;
  box16_t h1;
  box16_t h2;
  box16_t h3;
  box16_t h4;
  box16_t h5;
  box16_t h6;
  box16_t h7;
  box16_t h8;
  box16_t h9;
  box16_t h10;
  box16_t h11;
  box16_t h12;
  box16_t h13;
  box16_t h14;
  box16_t h15;
  box16_t h16;
  box16_t h17;
  box16_t h18;
  box16_t h19;
  box16_t h20;
  initial begin
    h1 = new;
    h2 = new;
    h3 = new;
    h4 = new;
    h5 = new;
    h6 = new;
    h7 = new;
    h8 = new;
    h9 = new;
    h10 = new;
    h11 = new;
    h12 = new;
    h13 = new;
    h14 = new;
    h15 = new;
    h16 = new;
    h17 = new;
    h18 = new;
    h19 = new;
    h20 = new;
  end
endmodule
