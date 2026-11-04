// § foreachThisArrAtThisToken207 (a nested class; a foreach inside fork and inside another loop; names of 1, 4, 5 and 12 letters)
package p;
  class Outer;
    class Inner;
      int q [$];
      int abcd [2];
      int abcde [2];
      int twelve_chars [2];
      task t();
        fork
          foreach (this.q[i]) q[i] = i;
        join
        for (int n = 0; n < 2; n++)
          foreach (this.abcd[i]) abcd[i] = n;
        foreach (this.abcde[i]) abcde[i] = 1;
        foreach (this.twelve_chars[i]) twelve_chars[i] = 2;
      endtask
    endclass
    Inner in;
  endclass
endpackage
module top; endmodule
