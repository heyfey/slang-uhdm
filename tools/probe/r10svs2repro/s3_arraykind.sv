// r10svs2 ARM s3 — EVERY ARRAY KIND, all parens-less.
// dynamic / queue / associative / FIXED unpacked.  If golden's rule keys on the
// array KIND rather than on the parens, this arm is where it shows.
class ak;
  int dyn[];            // dynamic
  int que[$];           // queue
  int asc[string];      // associative
  int fix[8];           // FIXED unpacked (size is legal here too)

  function int f();
    int a, b, c, e, g, h, i, j;
    string k;
    a = dyn.size;       // dynamic
    b = que.size;       // queue
    c = asc.size;       // assoc size
    e = asc.num;        // assoc num  -- the OTHER spelling
    // g = fix.size;    // REMOVED: slang REJECTS `size` on a FIXED unpacked
    //                  // array ("invalid member access for type 'int$[8]'")
    //                  // while Surelog ACCEPTS it -> unmeasurable cell, see README.
    g = 0;
    h = asc.exists("k");// assoc exists NEEDS an argument -> always parens-ful
    i = asc.first(k);   // assoc first NEEDS a ref argument -> always parens-ful
    j = que.size();     // POSITIVE CONTROL in the same arm
    return a + b + c + e + g + h + i + j;
  endfunction
endclass

module top;
  ak o;
  initial begin
    o = new();
    $display("%0d", o.f());
  end
endmodule
