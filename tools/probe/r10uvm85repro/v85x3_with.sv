// v85x3 — the `with` clause and the array locator/reduction family in statement
// position.  slang models the `with` expression as an ARGUMENT of the call, so
// the moment this law starts emitting arguments at depth 1 those iterator
// expressions become NEW objects.  Golden's shape for each is the question.
module v85x3;
  class in3v;
    int arr[$];
  endclass
  class c3v;
    int      q[$];
    in3v     h;
    int      n;
    function void f(int k);
      void'(this.q.find_first_index() with (item == 3));   // L14 depth1 + with
      void'(this.q.find_index() with (item > k));          // L15
      void'(this.q.find() with (item == 3));               // L16
      void'(this.q.min());                                 // L17 no with
      void'(this.q.max() with (item));                     // L18
      void'(this.q.unique());                              // L19
      void'(this.q.unique_index());                        // L20
      void'(this.q.sum());                                 // L21 reduction, 0 args
      void'(this.q.sum() with (item * 2));                 // L22 reduction + with
      void'(this.q.product());                             // L23
      void'(this.q.and());                                 // L24
      void'(this.q.or() with (item));                      // L25
      void'(this.q.xor());                                 // L26
      this.q.sort() with (item);                           // L27 stmt sort+with
      this.q.rsort() with (item);                          // L28
      void'(this.h.arr.find_first_index() with (item==3)); // L29 depth2 + with
      void'(this.h.arr.sum() with (item));                 // L30 depth2
      this.h.arr.sort() with (item);                       // L31 depth2
      this.n = 0;
    endfunction
  endclass
endmodule
