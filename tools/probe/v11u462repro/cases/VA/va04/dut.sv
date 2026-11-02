// § clsMethodOwnAutomatic462
class C #(int W = 2);
  function automatic logic [W-1:0] f(); return '1; endfunction
endclass
module top;
  C #(4) c;
  initial c = new;
endmodule
