const fz = require('zigbee-herdsman-converters/converters/fromZigbee');
const tz = require('zigbee-herdsman-converters/converters/toZigbee');
const exposes = require('zigbee-herdsman-converters/lib/exposes');
const reporting = require('zigbee-herdsman-converters/lib/reporting');
const extend = require('zigbee-herdsman-converters/lib/extend');
const e = exposes.presets;
const ea = exposes.access;
const ota = require('zigbee-herdsman-converters/lib/ota');

const definition = {
    zigbeeModel: ['E21-N1EA'], // The model ID from: Device with modelID 'lumi.sens' is not supported.
    model: 'E21-N1EA', // Vendor model number, look on the device for a model number
    vendor: 'sengled', // Vendor of the device (only used for documentation and startup logging)
    description: 'Elements plus color (A19)', // Description of the device, copy from vendor site. (only used for documentation and startup logging)
    extend: extend.light_onoff_brightness_colortemp_color(),
};

module.exports = definition;