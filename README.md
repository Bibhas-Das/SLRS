
<body>
<header>
    <h1>Static Located Reverse Shell (SLRS)</h1>
</header>
<section>
    <h2>Prerequisites</h2>
    <p>Ensure your Linux machine has the following installed:</p>
    <ul>
        <li><strong>PHP</strong></li>
        <li><strong>Python 3</strong></li>
        <li>Python packages:
            <ul>
                <li><code>os</code></li>
                <li><code>sys</code></li>
                <li><code>socket</code></li>
                <li><code>uuid</code></li>
                <li><code>json</code></li>
                <li><code>requests</code></li>
                <li><code>time</code></li>
                <li><code>subprocess</code></li>
            </ul>
        </li>
    </ul>
    <p>Install these packages using the following command:</p>
    <pre><code>pip3 install &lt;package-name&gt;</code></pre>
</section>
<section>
    <h2>Starting the PHP Server</h2>
    <p>Run the following command to start a PHP server on your local device:</p>
    <pre><code>sudo php -S 127.0.0.1:80</code></pre>
</section>
<section>
    <h2>Executing the Exploit</h2>
    <ol>
        <li>Send the <code>exploit.py</code> file to the remote device.</li>
        <li>Execute the file on the remote device:
            <pre><code>python3 exploit.py &amp;</code></pre>
        </li>
    </ol>
</section>
<section>
    <h2>Starting the Shell</h2>
    <p>On your local device, start <code>shell.py</code> using the following command:</p>
    <pre><code>python3 shell.py</code></pre>
    <p>Ensure a proper network connection for successful access. For local network setups, use the local device's IP where the PHP server is running. If needed, use port forwarding:</p>
    <pre><code>~/telebit http 80</code></pre>
    <p>Then run the PHP server on <code>localhost</code> on port <code>80</code>.</p>
</section>
<section>
    <h2>Compatibility</h2>
    <p>The exploit is compatible with both <strong>Windows</strong> and <strong>Linux</strong>. However, on Windows, security settings like Windows Defender may interfere. Disable Defender if necessary.</p>
</section>
<section>
    <h2>Final Steps</h2>
    <p>After cloning this repository or extracting the files, run the following command to get full details:</p>
    <pre><code>sh SLRS.sh</code></pre>
    <p>This will automatically generate the required files and provide step-by-step instructions.</p>
</section>
<footer>
    <p>Thank you for using SLRS!</p>
</footer>
</body>
</html>
