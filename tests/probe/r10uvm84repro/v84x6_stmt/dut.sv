// v84x6 — STATEMENT KINDS around the deep chain.
module v84x6;
  class in6x;
    int fld;
    int arr[$];
  endclass
  class c6x;
    in6x h;
    int  q[$];
    int  n;
    function void f(int i);
      case (this.h.fld)
        0: n = 0;
        default: n = 1;
      endcase
      case (1)
        this.h.fld: n = 2;         // L17 deep chain as a CASE ITEM
        default: n = 3;
      endcase
      if (this.h.fld) n = 4;       // L20
      while (this.h.fld > 0) n = 5;
      repeat (this.h.fld) n = 6;   // L22 repeat count
      do n = 7; while (this.h.fld > 1);
      for (int k = 0; k < this.h.arr.size(); k++) n = k;
      foreach (this.q[j]) n = this.h.arr[j];
      assert (this.h.fld > 0);     // L26 immediate assert
      n = this.h.fld inside {1, 2, 3};  // L27 inside
      n = {this.h.fld, this.h.fld};     // L28 concat, twice
      n = this.h.fld ? this.h.arr[0] : this.h.arr.size();  // L29 all three ternary slots
    endfunction
  endclass
endmodule
