import React from 'react';
import styles from "../styles/Home.module.css"

class Clock extends React.Component {
  constructor(props) {
    super(props);
    this.state = { date: new Date() };
    this.circle = React.createRef();
    this.dot = React.createRef();
  }

  componentDidMount() {
    this.timerID = setInterval(
      () => {
        if (this.state.date.getHours() < 10) {
          document.querySelector(".hoursZero").style.display = 'block';
        } else {
          document.querySelector(".hoursZero").style.display = 'none';
        }

        if (this.state.date.getMinutes() < 10) {
          document.querySelector(".minutesZero").style.display = 'block';
        } else {
          document.querySelector(".minutesZero").style.display = 'none';
        }

        this.circle.current.setAttribute("stroke-dashoffset", 628 - (628 * this.state.date.getSeconds()) / 60);
        this.dot.current.style.transform = `rotate(${this.state.date.getSeconds() * 6}deg)`;

        this.tick();
      },
      1000
    );
  }

  componentWillUnmount() {
    clearInterval(this.timerID);
  }

  tick() {
    this.setState({
      date: new Date()
    });
  }


  render() {
    return (
      <div className={styles.clock_wrapper}>
        {/* <header className="clock-wrapper__header">
          <h2 className="clock-wrapper__header__title">clock</h2>
          <h4 className="clock-wrapper__header__subtitle">pacific time</h4>
        </header> */}
        <main className={styles.clock_wrapper__main}>
          <div className={styles.clock_wrapper__main__circle}>
            <div className={styles.clock_wrapper__main__circle__dot} ref={this.dot}></div>
            <svg className={styles.clock_wrapper__main__circle__svg}>
              <circle cx={108} cy={108} r={100}></circle>
              <circle cx={108} cy={108} r={100} strokeDasharray={628} ref={this.circle}></circle>
            </svg>
            <h2 className={styles.clock_wrapper__main__circle__time}> <span className='zero hoursZero'>0</span>{this.state.date.getHours()}<span className='dots'>:</span><span className="zero minutesZero">0</span>{this.state.date.getMinutes()}</h2>
          </div>
        </main>
      </div>
    );
  }
}

export default Clock;

