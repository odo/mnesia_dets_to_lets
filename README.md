

#An experiment to swap DETS for LETS as a backend for mnesia.#


__Authors:__ Florian Odronitz ([`fo@twoflaots.com`](mailto:fo@twoflaots.com)).

This is an experimental setup to use LETS (https://github.com/norton/lets/) as a backend for Mnesia.
To make life easier, meck (https://github.com/eproxus/meck) is used to mock calls to DETS with calls to LETS. This means that after patching, nodes set to 'disc\_only\_copies' will use leveldb (http://code.google.com/p/leveldb/). 

<h2>Setup</h2>

<p>This is intended for Mnesia 4.6 which comes with Erlang/OTP R15B.</p>

To compile the test for Mnesia go to your mnesia test directory (most likely /usr/local/otp\_src\_R15B/lib/mnesia/test) and type:
<pre><tt>$ erl -make</tt></pre>
If that fails, please consult the README file in the same directory.

To prepare mnesia_dets_to_lets do the following:
<pre><tt>$ mkdir working-directory-name
$ cd working-directory-name
$ git clone git://github.com/odo/mnesia_dets_to_lets.git mnesia_dets_to_lets
$ cd mnesia_dets_to_lets
</tt></pre>

Make sure the path to mnesia in Makefile is correct.
Then continue: 

<pre><tt>$ rebar get-deps
$ make
$ git clone git://github.com/odo/mnesia_dets_to_lets.git mnesia_dets_to_lets
$ cd mnesia_dets_to_lets
</tt></pre>

<h2>Usage</h2>

To start with all relevant paths set, type:
<pre><tt>$ make start</tt></pre>

Up till now, everything is standard and you can run Mnesia test suites:
<pre><tt>$ dets_to_lets:test(durability).</tt></pre>

To run all tests (takes a long time), type:
<pre><tt>$ dets_to_lets:test(all).</tt></pre>

To swap the DETS for LETS use:
<pre><tt>$ dets_to_lets:init().</tt></pre>

Now you can continue testing...