package p;
  class base;
    typedef enum int { E0 = 0, E1 = 1 } e_t;
  endclass
  class holder;
    base::e_t ev;
    int r;
    function void go();
      ev = base::E1;
      r = (ev == base::E0);
      r = int'(base::E1);
    endfunction
  endclass
endpackage

module top;
  import p::*;
  int z;
  base::e_t mv;
  initial begin
    mv = base::E1;
    z = int'(base::E0);
  end
endmodule
