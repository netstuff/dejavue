import { useState } from "react";
import { Head, Link } from "@inertiajs/react";

export default function Index({ name }: { name: string }) {
  const [count, setCount] = useState(0);

  return (
    <>
      <Head title="Home" />
      <main>
        <div className="rocket" style={{ top: -count * 10 }}>
          <svg className="figure" viewBox="0 0 508 268" aria-hidden="true">
            <path d="M305.2 156.6c0 4.6-.5 9-1.6 13.2-2.5-4.4-5.6-8.4-9.2-12-4.6-4.6-10-8.4-16-11.2 2.8-11.2 4.5-22.9 5-34.6 1.8 1.4 3.5 2.9 5 4.5 10.5 10.3 16.8 24.5 16.8 40.1zm-75-10c-6 2.8-11.4 6.6-16 11.2-3.5 3.6-6.6 7.6-9.1 12-1-4.3-1.6-8.7-1.6-13.2 0-15.7 6.3-29.9 16.6-40.1 1.6-1.6 3.3-3.1 5.1-4.5.6 11.8 2.2 23.4 5 34.6z" fill="#2E3B39" fillRule="nonzero" />
            <path d="M282.981 152.6c16.125-48.1 6.375-104-29.25-142.6-35.625 38.5-45.25 94.5-29.25 142.6h58.5z" stroke="#FFF" strokeWidth="3.396" fill="#6DDCBD" />
            <path d="M271 29.7c-4.4-10.6-9.9-20.6-16.6-29.7-6.7 9-12.2 19-16.6 29.7H271z" stroke="#FFF" strokeWidth="3" fill="#2E3B39" />
            <circle stroke="#FFF" strokeWidth="7" fill="none" cx="254.3" cy="76.8" r="12.2" />
          </svg>
        </div>
        <h1>
          Welcome, <span>{name}</span>!
        </h1>
        <h2>The install worked successfully! Congratulations!</h2>
        <p>
          <Link href="/" className="/">Index</Link>
        </p>
        <a className="logo" href="https://www.djangoproject.com/" target="_blank" rel="noopener">
          Django
        </a>
        <div className="counter">
          <button onClick={() => setCount(Math.max(0, count - 1))}>-</button>
          <span>{count}</span>
          <button onClick={() => setCount(Math.min(30, count + 1))}>+</button>
        </div>
      </main>
      <footer>
        <a className="option" href="https://docs.djangoproject.com/en/5.2/" target="_blank" rel="noopener">
          <p>
            <span className="option__heading">Django Documentation</span>
            <br />
            Topics, references, &amp; how-to's
          </p>
        </a>
        <a className="option" href="https://docs.djangoproject.com/en/5.2/intro/tutorial01/" target="_blank" rel="noopener">
          <p>
            <span className="option__heading">Tutorial: A Polling App</span>
            <br />
            Get started with Django
          </p>
        </a>
        <a className="option" href="https://www.djangoproject.com/community/" target="_blank" rel="noopener">
          <p>
            <span className="option__heading">Django Community</span>
            <br />
            Connect, get help, or contribute
          </p>
        </a>
      </footer>
    </>
  );
}
