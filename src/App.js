import React, { useState } from "react";
import "./App.css";

function App() {
  const [display, setDisplay] = useState("");

  const handleClick = (value) => {
    if (value === "=") {
      try {
        setDisplay(eval(display).toString()); // simple eval for demo only
      } catch {
        setDisplay("Error");
      }
    } else if (value === "C") {
      setDisplay("");
    } else {
      setDisplay(display + value);
    }
  };

  const buttons = [
    "7", "8", "9", "/",
    "4", "5", "6", "*",
    "1", "2", "3", "-",
    "0", ".", "=", "+"
  ];

  return (
    <div className="calculator-container">
      <div className="calculator">
        <h1 style={{ color: "white" }}>Chinam's Calculator</h1>
        <div className="display">{display || "0"}</div>
        <div className="buttons">
          {buttons.map((btn) => (
            <button
              key={btn}
              onClick={() => handleClick(btn)}
              className={btn === "=" ? "equals" : ""}
            >
              {btn}
            </button>
          ))}
          <button className="clear" onClick={() => handleClick("C")}>
            C
          </button>
        </div>
      </div>
    </div>
  );
}

export default App;
