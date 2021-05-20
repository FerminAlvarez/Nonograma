import React from 'react';

class Square extends React.Component {
    render() {
        return (
            <button className={"square" + (this.props.value === "#" ? "-painted" : "")} onClick={this.props.onClick}>
                {this.props.value !== '_' ? this.props.value : null}
            </button>
        );
    }
}

export default Square;