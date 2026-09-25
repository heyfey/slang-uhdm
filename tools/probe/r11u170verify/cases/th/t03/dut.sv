// § thisPathFormByPosition157
package p;
  class c;
    rand int x; int lim;
    constraint k { this.x < this.lim; }
    task t(output int r);
      r = this.lim;
      #1 this.x = r;
    endtask
  endclass
endpackage
module top; p::c o; int r; initial begin o = new; o.t(r); end endmodule
