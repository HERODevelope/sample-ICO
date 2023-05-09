import React, { Component} from 'react';

export default class Progressbar extends Component {
  render() {
    const containerStyles = {
      height: 20,
      width: '100%',
      backgroundColor: "#e0e0de",
      borderRadius: 50,
    }

    const fillerStyles = {
      height: '100%',
      width: `${this.props.completed}%`,
      backgroundColor: this.props.bgcolor,
      borderRadius: 'inherit',
      textAlign: 'right'
    }

    const labelStyles = {
      padding: 0,
      color: 'white',
      fontWeight: 'bold',
      fontSize : 16
    }

    return (
      <div style={containerStyles}>
        <div style={fillerStyles}>
          <span style={labelStyles}>{`${this.props.completed}%`}</span>
        </div>
      </div>
    );
  }
}

