// v115_b — USE SITES: process::self() in every expression position and the
// p.status()/p.kill()/p.await() method calls, plus arrays/queues of handles.
module mb_top;
  initial begin
    process q = process::self();      // initialised AT DECLARATION
    process r;
    process ar [2];                   // fixed ARRAY of handles
    process aq [$];                   // QUEUE of handles
    process ad [];                    // DYNAMIC array
    int st;
    r = process::self();              // assignment Rhs
    if (q.status() == process::RUNNING)   // condition
      q.kill();
    q.await();
    st = int'(q.status());
    ar[0] = process::self();
    aq.push_back(process::self());
    ad = new[2];
    ad[0] = r;
    $display("%0d", int'(process::self().status()));  // ARGUMENT + chained
  end
endmodule
