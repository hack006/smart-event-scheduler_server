var getCurrentDate = function () {
    return new Date();
};

var DAY_IN_SECONDS = 60 * 60 * 24;

/**
 * Add time interval in seconds to the current date
 * @param seconds
 */
Date.prototype.addSeconds = function (seconds) {
    this.setTime(this.getTime() + seconds * (1000));
};

/**
 *Add time interval in seconds and return as new date object
 * @param seconds
 * @returns {Date}
 */
Date.prototype.cloneAddSeconds = function (seconds) {
    var newDate = new Date(this.getTime());
    newDate.addSeconds(seconds);
    return newDate
};

function TimeInterval (millis) {
    this._millis = millis;
    this._ms = null;
    this._s = null;
    this._min = null;
    this._h = null;
    this._d = null;
    this._m = null;
    this._y = null;

    var SECOND_IN_MILLIS = 1000;
    var MINUTE_IN_MILLIS = SECOND_IN_MILLIS * 60;
    var HOUR_IN_MILLIS = MINUTE_IN_MILLIS * 60;
    var DAY_IN_MILLIS = HOUR_IN_MILLIS * 24;
    var MONTH_IN_MILLIS = DAY_IN_MILLIS * 30;
    var YEAR_IN_MILLIS = DAY_IN_MILLIS * 365.25;

    this._recalculate = function () {
        var remainingMillis = this._millis;

        var calcIntegerUpdateRemainder = function (dividerInMillis) {
            var integerPart = Math.floor(remainingMillis / dividerInMillis);
            remainingMillis = remainingMillis % dividerInMillis

            return integerPart;
        };

        this._y = calcIntegerUpdateRemainder(YEAR_IN_MILLIS);
        this._m = calcIntegerUpdateRemainder(MONTH_IN_MILLIS);
        this._d = calcIntegerUpdateRemainder(DAY_IN_MILLIS);
        this._h = calcIntegerUpdateRemainder(HOUR_IN_MILLIS);
        this._min = calcIntegerUpdateRemainder(MINUTE_IN_MILLIS);
        this._s = calcIntegerUpdateRemainder(SECOND_IN_MILLIS);
    };

    this._recalculate();
}

TimeInterval.prototype.getYears = function () {
    return this._y;
};
TimeInterval.prototype.getMonths = function () {
    return this._m;
};
TimeInterval.prototype.getDays = function () {
    return this._d;
};
TimeInterval.prototype.getHours = function () {
    return this._h;
};
TimeInterval.prototype.getMinutes = function () {
    return this._min;
};
TimeInterval.prototype.getSeconds = function () {
    return this._s;
};