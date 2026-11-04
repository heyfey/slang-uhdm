// § foreachLocalArrTsOwnListing246
package p;
  typedef bit [8-1:0] b_t;
  class c;
    task t();
      b_t a[];
      foreach (a[i]) a[i] = i;
    endtask
  endclass
endpackage
module top;
endmodule
