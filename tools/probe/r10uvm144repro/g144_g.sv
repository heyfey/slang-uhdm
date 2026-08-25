// r10uvm144 arm G — WHERE a CONSTRUCTOR's body locals are LISTED, and which of
// them a call argument may bind.  The t38a counter-witness said "scalar ints in
// a long body BIND"; arm E said "a queue in a short body does NOT".  This arm
// separates the candidate features one at a time.
package p144g;
  class B144;
    extern static function void qi(ref int a[$]);
    extern static function void si(ref int a);
  endclass
  function void B144::qi(ref int a[$]); endfunction
  function void B144::si(ref int a); endfunction
  function automatic void bq144(ref int a[$]); endfunction
  function automatic void bs144(ref int a); endfunction

  // g01 ctor, SCALAR local, one call + one statement
  class G01; int w; function new(); int s1;    B144::si(s1); w = 1; endfunction endclass
  // g02 ctor, QUEUE local, one call + one statement
  class G02; int w; function new(); int q2[$]; B144::qi(q2); w = 2; endfunction endclass
  // g03 ctor, SCALAR local WITH an initialiser
  class G03; int w; function new(); int s3 = 7; B144::si(s3); w = 3; endfunction endclass
  // g04 ctor, QUEUE local, but the body also writes the local first
  class G04; int w; function new(); int q4[$]; q4.delete(); B144::qi(q4); w = 4; endfunction endclass
  // g05 ctor, SCALAR local, BARE call
  class G05; int w; function new(); int s5;    bs144(s5); w = 5; endfunction endclass
  // g06 ctor, QUEUE local, BARE call
  class G06; int w; function new(); int q6[$]; bq144(q6); w = 6; endfunction endclass
  // g07 ORDINARY method twins
  class G07; int w; function void m(); int s7;    B144::si(s7); w = 7; endfunction endclass
  class G08; int w; function void m(); int q8[$]; B144::qi(q8); w = 8; endfunction endclass
  // g09 ctor, BOTH a scalar and a queue local
  class G09; int w; function new(); int s9; int q9[$]; B144::si(s9); B144::qi(q9); w = 9; endfunction endclass
  // g10 ctor, SCALAR local, the call is the ONLY statement (no body scope)
  class G10; function new(); int s10; B144::si(s10); endfunction endclass
  // g11 ctor, SCALAR local, a LONG body (the t38a shape)
  class G11; int w;
    function new(int a);
      int lb;
      int li = 7;
      lb = a;
      w = li;
      B144::si(lb);
      B144::si(li);
      bs144(lb);
      if (a == 0) w = 1;
      w = a + lb + li;
    endfunction
  endclass
endpackage
