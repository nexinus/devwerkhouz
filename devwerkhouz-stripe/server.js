require('dotenv').config();
const express = require('express');
const path = require('path');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const bodyParser = require('body-parser');

const app = express();
app.use(express.json());
app.use(express.static('public'));

// For webhook raw body:
app.use('/webhook', bodyParser.raw({ type: 'application/json' }));

// Create Checkout Session for a subscription
app.post('/create-checkout-session', express.json(), async (req, res) => {
  try {
    const { priceId, customerEmail } = req.body; // priceId is like 'price_ABC...'

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [{ price: priceId, quantity: 1 }],
      customer_email: customerEmail || undefined, // optional prefill
      allow_promotion_codes: true,
      subscription_data: {
        // If you want a 7-day trial:
        // trial_period_days: 7,
        metadata: { product: 'DevWerkhouz Pro' }
      },
      success_url: `${process.env.BASE_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${process.env.BASE_URL}/pricing`,
    });

    res.json({ id: session.id, url: session.url });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Webhook to receive Checkout and Subscription events
app.post('/webhook', (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.log('Webhook signature verification failed.', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the events you care about
  switch (event.type) {
    case 'checkout.session.completed':
      // Payment & subscription was created
      const session = event.data.object;
      // Save session.customer or session.customer_email and session.subscription to DB
      console.log('Checkout session completed:', session.id);
      break;
    case 'invoice.payment_succeeded':
      // recurring payment success
      console.log('Invoice paid:', event.data.object.id);
      break;
    case 'invoice.payment_failed':
      // handle failed payment
      console.log('Invoice failed:', event.data.object.id);
      break;
    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  res.json({ received: true });
});

app.get('/create-portal-session', async (req, res) => {
  // TODO: you must authenticate user in production and look up the Stripe customer ID in your DB
  const { customer } = req.query; // e.g. customer ID
  const session = await stripe.billingPortal.sessions.create({
    customer,
    return_url: process.env.BASE_URL + '/account'
  });
  res.redirect(session.url);
});

app.get('/success', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'success.html'));
});

app.get('/cancel', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'cancel.html'));
});

const PORT = process.env.PORT || 4242;
app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));