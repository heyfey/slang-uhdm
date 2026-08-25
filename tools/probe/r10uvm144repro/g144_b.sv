package p144b;

  class B144;
    int v;
    extern static function void grb(ref B144 blks[$]);
    extern static function void gri(ref int iblks[$]);
    extern static function void sc(ref B144 h);
  endclass

  function void B144::grb(ref B144 blks[$]);
  endfunction
  function void B144::gri(ref int iblks[$]);
  endfunction
  function void B144::sc(ref B144 h);
  endfunction

  class M144;
    int w;
    // b1: THE CORPUS SHAPE - queue-of-class local, class-scope static call,
    // extra statement so the body blockifies.
    virtual function void b1();
      B144 q1[$];
      B144::grb(q1);
      w = 1;
    endfunction
    // b2: the SAME with an int queue
    virtual function void b2();
      int q2[$];
      B144::gri(q2);
      w = 2;
    endfunction
    // b3: SCALAR class handle
    virtual function void b3();
      B144 s3;
      B144::sc(s3);
      w = 3;
    endfunction
    // b4: non-virtual
    function void b4();
      B144 q4[$];
      B144::grb(q4);
      w = 4;
    endfunction
    // b5: the ONLY statement (no blockify)
    virtual function void b5();
      B144 q5[$];
      B144::grb(q5);
    endfunction
  endclass

endpackage
