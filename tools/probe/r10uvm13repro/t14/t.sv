package p1;
  typedef enum int { PE0 = 0, PE1 = 1, PE2 = 2 } pe_t;
  int gv;
  function void sink(int a);
    gv = a;
  endfunction
  class k;
    typedef enum int { KE0 = 0, KE1 = 1 } ke_t;
    int r;
    pe_t m;
    function void inl();
      r = PE1;             // A plain assign, pkg enum
      if (m == PE1) r = 1; // B if-condition, pkg enum
      case (m)
        PE2: r = 2;        // C case ITEM, pkg enum
        default: r = 3;
      endcase
      sink(PE1);           // D user call argument, pkg enum
      $display("%0d", PE1);// E system call argument, pkg enum
      r = KE1;             // F plain assign, class enum
      if (r == KE1) r = 4; // G if-condition, class enum
      sink(KE1);           // H user call arg, class enum
      m = pe_t'(PE2);      // I cast operand
      r = PE1 + PE2;       // J operation operand
    endfunction
  endclass
endpackage

module top;
  import p1::*;
  p1::k h;
  initial h = new();
endmodule
